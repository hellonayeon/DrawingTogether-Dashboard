package kr.ac.hansung.dao;

import java.util.List;

import javax.transaction.Transactional;

import org.hibernate.query.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import kr.ac.hansung.model.Realtime;

@Repository
@Transactional
public class RealtimeDao {
	
	@Autowired
	private SessionFactory sessionFactory;

	public Realtime getCurrentRealtimeData() {
		
		Session session = sessionFactory.getCurrentSession();
		
		String hql = "from Realtime"; // TODO: load only last one record
		
		Query<Realtime> query = session.createQuery(hql, Realtime.class);
		
		if (query.getResultList().size() == 0)
			return null;
		
		
		return query.getResultList().get(query.getResultList().size()-1);
	}
	
	public List<Realtime> getAllRealtimeData() {
		Session session = sessionFactory.getCurrentSession();

		Query<Realtime> query = session.createQuery("from Realtime", Realtime.class);

		return  query.getResultList();
	}

	public List<Realtime> getRecentRealtimData() {
		Session session = sessionFactory.getCurrentSession();
		
		Query<Long> countQuery = session.createQuery("select count(*) from Realtime realtime", Long.class);	
		int count = countQuery.uniqueResult().intValue(); // 실시간 데이터 레코드 개수
		
		Query<Realtime> recordQuery = session.createQuery("from Realtime", Realtime.class);
		
		if(count > 11) {
			recordQuery.setFirstResult(count - 10);
			recordQuery.setMaxResults(count);
		}
		
		return recordQuery.getResultList();
	}
	

}
